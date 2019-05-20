-- kong支持两种数据库 
-- PostgreSQL & Cassandra 可以选择之一或者都配置
-- 主体主要分为两部分 - up & teardown

return {
	postgresql = {
		-- 当 kong migrations up 执行时调用
		-- string 主要配置涉及增加操作
		up = [[
			CREATE TABLE IF NOT EXISTS "my_plugin_table" (
				"id"           UUID                         PRIMARY KEY,
				"created_at"   TIMESTAMP WITHOUT TIME ZONE,
				"col1"         TEXT
			);

			DO $$
			BEGIN
				CREATE INDEX IF NOT EXISTS "my_plugin_table_col1"
												ON "my_plugin_table" ("col1");
			EXCEPTION WHEN UNDEFINED_COLUMN THEN
				-- Do nothing, accept existing state
			END$$;
		]],
		-- 当 kong migrations finish ?? 执行时调用
		-- @param connector  用于执行 query 等
		-- @param helpers 
		-- function  配置涉及 非增加 的其他操作
		teardown = function(connector, helpers)
			assert(connector:connect_migrations())
			assert(connector:query([[
        		DO $$
        		BEGIN
          			ALTER TABLE IF EXISTS ONLY "my_plugin_table" DROP "col1";
        		EXCEPTION WHEN UNDEFINED_COLUMN THEN
          			-- Do nothing, accept existing state
        		END$$;
      		]]))
		end,
	},

	cassandra = {
		up = [[
			CREATE INDEX IF NOT EXISTS routes_name_idx ON routes(name);
		]],
		teardown = function(connector, helpers)
			assert(connector:connect_migrations())
			assert(connector:query("DROP TABLE IF EXISTS schema_migrations"))
		end,
	}
}

-- 最佳实践
-- 对操作的sql：尽量做到有判断性
-- 比如 ： 用DROP TABLE IF EXISTS 代替DROP TABLE
--        CREATE INDEX IF NOT EXIST 代替 CREATE INDEX

-- 注意 PostgreSQL & Cassandra 的语法差异