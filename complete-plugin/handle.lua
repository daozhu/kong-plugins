-- 创建插件
local BasePlugin 	 = require "kong.plugins.base_plugin"
local CustomerHandle = BasePlugin.extend()

-- 也可以引用现有的模块里面的逻辑(function) -- 在相应的handle中直接使用   -->模块化抽象封装
local access 	     = require "kong.plugins.plugin_name.access"

-- constructor
function CustomerHandle:new()
	CustomerHandle.super.new(self, 'test-plugin')

	-- my logic ...
end

-- 插件的执行顺序 - 越大越优先
CustomHandler.PRIORITY = 10



-- init-worker --> nginx worker 进程启动时调用 ->> init_worker_by_lua
function CustomerHandle:init_worker()
	CustomerHandle.super.init_worker(self)

	-- my logic ...
end

--  certificate --> ssl 握手验证期间调用 ->> ssl_certificate_by_lua_block
--  param - config : a lua table thant user given . according by the schema.lua
function CustomerHandle:certificate(config)
	CustomerHandle.super.certificate(self)

	-- my logic ...
end

-- rewrite 仅当此插件声明为 global plugin 时有效。 --> 每次请求都会调用  rewrite_by_lua_block
function CustomerHandle:rewrite(config)
	CustomerHandle.super.rewrite(self)

	-- my logic
end

-- access  ->>每次请求到来之后，且在转给负载均衡服务之前调用  access_by_lua
function CustomerHandle:access(config)
	CustomerHandle.super.access(self)

	-- my logic ...

	-- config 为 schema中的配置  key_names 为其中的一个值  service.host 递归值
	kong.log.inspect(config.key1)
	kong.log.inspect(config.service.host)

	-- 执行已经加载的模块里面的function
	access.execute(config)
end

-- header_filter 从负载均衡服务那里收到所有的 response headers bytes 时调用
function CustomerHandle:header_filter(config)
	CustomerHandle.super.header_filter(self)

	-- my logic ...
end

-- body_filter  每次从负载均衡服务那里收到 a chunk of body 时调用，在最终返回给client时可能会被调用多次
function CustomerHandle:body_filter(config)
	CustomerHandle.super.body_filter(self)

	-- my logic ...
end
	
-- log   所有的数据发给client之后调用
function CustomerHandle:log(config)
	CustomerHandle.super.log(self)

	-- my logic ...
end

return CustomerHandle