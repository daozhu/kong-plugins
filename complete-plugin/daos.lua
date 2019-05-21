-- the db Schema

-- 可用的dao实体 : 全局单例 : kong.db
-- local services_dao 	= kong.db.services
-- local routes_dao 	= kong.db.routes
-- local consumers_dao 	= kong.db.consumers
-- local plugins_dao 	= kong.dao.plugins

-- URI : https://docs.konghq.com/1.1.x/plugin-development/custom-entities/   ： https://docs.konghq.com/1.1.x/plugin-development/entities-cache/

-- 字段类型
local typedefs = require "kong.db.schema.typedefs"

-- cache  : 有两个等级 :  1 nginx work process 级别 2， nginx 级别(不同的work process)
--						即： 如果是1 命中，则直接从lua memery cache中获取，如果是2 ，则从SHM中获取
-- 缓存操作方法：
-- 		value, err = cache:get(key, opts?, cb, ...) 获取和设置一个值： 如果不存在，则用cb来获取。 否则返回ngx.ERR 级别的错误, 第四个及之后的参数是第三个的形参。第三个为可调用的封装
--      ttl, err, value = cache:probe(key)  检查是够存在
-- 		cache:invalidate_local(key)  仅在本节点删除key
--		cache:invalidate(key)        在集群中删除(即：删除之后广播给集群中其他节点)
--		cache:purge() 删除所有本节点
local cache = kong.cache


local keyauth_credentials = {
	-- Array  有时候可以是复合组件
	primary_key = { "id" },
	-- String  被用于 kong.db.[name]  so here is : kong.db.keyauth_credentials
	name = "keyauth_credentials",
	-- String  用于admin api 中，可被美化的url结构参数：比如，此处 /keyauth_credentials/foo 则 key=>foo。 默认主键也可以 /keyauth_credentials/123 则 id=>123
	endpoint_key = "key",
	-- array 对应于实体里面定义的属性 ， 定义了kong.db.<dao>:cache_key(arg1, arg2, arg3, ...) 函数的参数，参见：handle
	-- 能作为cache_key 的，必须是唯一性的组合。 每次的curd。kong都会生成这个cache_key，并广播给所有的节点，以供缓存同步。父级缓存的变更会应该子级缓存
	cache_key = { "key" },
	-- 表结构 --字段及其规则
	fields = {
      {
        -- a value to be inserted by the DAO itself
        -- (think of serial id and the uniqueness of such required here)
        id = typedefs.uuid,
      },
      {
        -- also interted by the DAO itself
        created_at = typedefs.auto_timestamp_s,
      },
      {
        -- a foreign key to a consumer's id
        consumer = {
          type      = "foreign",
          reference = "consumers",
          default   = ngx.null,
          on_delete = "cascade",
        },
      },
      {
        -- a unique API key
        key = {
          type      = "string",
          required  = false,
          unique    = true,
          auto      = true,
        },
      },
    },
}

-- lua table 
return { keyauth_credentials = keyauth_credentials }


-- so , example

-- select insert update upsert delete
local entity, err, err_t = kong.db.keyauth_credentials:select({
  	id = "c77c50d2-5947-4904-9f37-fa36182a71a9"
})

if err then
  	kong.log.err("Error when inserting keyauth credential: " .. err)
  	return nil
end

if not entity then
  	kong.log.err("Could not find credential.")
  	return nil
end



