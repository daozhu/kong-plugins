-- 通过 LuaRocks 部署插件

package = "kong-plugin-myplugin" -- 前缀 kong-plugin 跟文件名匹配
version = "0.1.0-1"              -- 0.1.0 是代码版本 1 是rockspec版本，代码版本变化，则rockspec版本需要退回到1，
								 --    而，如果是rockspec文件变化但是代码没有变，则需保持代码版本号不变，rockspec版本增加

-- 解析出插件名称
local pluginName = package:match("^kong%-plugin%-(.+)$")  -- "myPlugin"

supported_platforms = {"linux", "macosx"}
source = {
  url = "http://github.com/Kong/kong-plugin.git",// url
  tag = "0.1.0"
}

description = {
  summary = "my pkugin",
  homepage = "www.baidu.com",
  license = "Apache 2.0"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    -- TODO: add any additional files that the plugin consists of
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}

-- 相关的命令：
-- 1， 	本地安装： 在有rockspec文件的目录执行: luarocks make . 
-- 2， 	打包安装 : luarocks pack <plugin-name> <version> 。 则，本例中，具体为 : luarocks pack kong-plugin-myplugin 0.1.0-1
--          2的命令，会生成一个rock的包。 so 
-- 3.1  通过.rock安装  luarocks install <rock-filename>  。本例中则为: luarocks install my-plugin-0.1.0-1.all.rock
-- 3.2  通过源码 ： 在rockspec文件目录执行 luarocks make : 插件会被安装在 kong/plugins/<plugin-name> 目录中
-- 3.3  ....

-- 在kong中加载自定义插件
-- 在插件列表里面配置 然后 kong restart
-- 

