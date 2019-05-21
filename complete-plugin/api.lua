-- 拓展api网关

-- endpoints 包含了大部分的CURD的操作
-- https://docs.konghq.com/1.1.x/pdk
local endpoints = require "kong.api.endpoints"

local credentials_schema = kong.db.keyauth_credentials.schema
local consumers_schema = kong.db.consumers.schema

return {
	["/consumers/:consumers/key-auth/:keyauth_credentials"] = {
		schema = credentials_schema,
		methods = {
			-- @param self :  Lapis request object. -- http://leafo.net/lapis/reference/actions.html#request-object
			-- @param db  -- DAO
			-- @param helpers
			before = function(self, db, helpers)
				local consumer, _, err_t = endpoints.select_entity(self, db, consumers_schema)
				if err_t then
					return endpoints.handle_error(err_t)
				end
				if not consumer then
					return kong.response.exit(404, { message = "Not found" })
				end

				self.consumer = consumer

				if self.req.method ~= "PUT" then
					local cred, _, err_t = endpoints.select_entity(self, db, credentials_schema)
					if err_t then
						return endpoints.handle_error(err_t)
					end

					if not cred or cred.consumer.id ~= consumer.id then
						return kong.response.exit(404, { message = "Not found" })
					end
					self.keyauth_credential = cred
					self.params.keyauth_credentials = cred.id
				end
			end,
			GET  = endpoints.get_entity_endpoint(credentials_schema),
			PUT  = function(self, db, helpers)
			self.args.post.consumer = { id = self.consumer.id }
				return endpoints.put_entity_endpoint(credentials_schema)(self, db, helpers)
			end,
		},
	},
}