# 官方 CENC 预警 API 代理（预留）

正式上线时，建议在此部署后端服务：

1. 向中国地震台网中心申请定制接口（[产品定制服务](https://data.earthquake.cn/cpdzfw/info/2025/334674087.html)）
2. 服务端维护与 `yjfw.cenc.ac.cn` 的长连接或轮询
3. iOS 客户端只访问你的 HTTPS 代理，避免在 App 内硬编码密钥

## 参考接口（需授权）

```
POST https://yjfw.cenc.ac.cn/api/earthquake/user/v1/register_user
POST https://yjfw.cenc.ac.cn/api/earthquake/event/v1/list
```

## 标准

中国地震局标准 **DB/T 113.2-2026**《地震预警信息发布 第2部分：信息接口》将于 2026-09-01 实施，对接时可参照其数据包结构。
