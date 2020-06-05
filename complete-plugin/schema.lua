-- 配置 以及 验证 一些 k-v 参数
-- 即：用户通过admin api 使用（开启或者更新）插件时，有哪些可用的参数项：如 --data "key=value"
-- 用户的这些请求参数会传给 handle中的被执行的function的形参：config


local typedefs = require "kong.db.schema.typedefs"

local function server_port(given_value, given_config)
	-- validation
	if given_value > 9000
		return false, " port too high"
	end

	if given_config.key1 == "value1" then 
		return true, nil, {port = 8080}
	end
end


return {
	-- 插件名字
	name: "plugin-name",
	-- 如果为true，只能用在services和routes
	no_consumer = true,
	-- k/v and it`s rule  -> table  超出的参数将视为无效返回
	fields = {
		-- type : string : “id”, “number”, “boolean”, “string”, “table”, “array”, “url”, “timestamp”
		--        array: must be an integer-indexed table (equivalent of arrays in Lua)
		-- required : boolean
		-- unique : boolean
		-- default : any 根据type定
		-- immutable : boolean :是否可变，默认false. 如果为true，则不能被修改
		-- enum : table : 整形索引（不显示指定索引） , value 的枚举。即：限制value的值需在该table内 
		-- regex : string : regex 验证value
		-- schema : table : type需为table：子rules, 即深度递归验证
		-- func : function : 匿名函数验证
		key1 = {type = "string", required = true, unique = true, default = "value1", immutable = true},
		-- config.service.host
		server = {
			type = "table",
			schema = {
				fields = {
					host = {type = "url", default = "http://example.com"},
					port = {type = "number", func = server_port, default = 80}
				}
			}
		}
	},
	-- 在使用 用户的传参 之前进行验证
	-- @param `schema` 		a table that param rules
	-- @param `config` 		a table that k/v params
	-- @param `dao`    		DAO instance
	-- @param `is_updating` boolean that whether or not the contxt is a update 
	-- @param `valid`    	boolean that whether or not the config is valid 
	-- @param `error`    	DAO`s error 
	entity_checks = function (schema, config, dao, is_updating, valid, error)
		-- verification

		return true
	end
}