Name: {{.serviceName}}
Host: {{.host}}
Port: {{.port}}

Kafka:
  Addr: ip:port
  Topic: topic
  Partition: 0
  BatchSize: 1

#database配置
MySQL:
  DSN: "user:pwd@tcp(ip:port)/database-name?charset=utf8mb4&parseTime=True&loc=Local"
  LogMode: true
  MaxOpenCons: 10
  MaxIdleCons: 10
  CreateBatchSize: 300
#redis配置
RedisConf:
  Host: ip:port
  Type: node
  # pass maybe is empty
  Pass:
#Auth配置,use the service name as secret
Auth:
  AccessSecret: {{.serviceName}}
  AccessExpire: 604800000
  RefreshExpire: 1296000000