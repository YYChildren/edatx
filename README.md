# edatx
解析 ipip.net datx 格式的Erlang代码

## 数据文件下载
<https://www.ipip.net/product/ip.html>


## 代码示例

```erlang
% 查询地级市精度的IP库

City = edatx_city:init("/path/to/mydata4vipday2.datx").
io:format("~ts,~ts,~ts,~ts~n", edatx_city:find("8.8.8.258", City)).
io:format("~ts,~ts,~ts,~ts~n", edatx_city:find("255.255.255.255", City)).

```

## 编译
```
rebar3 compile
```