package config

import (
	"github.com/zeromicro/go-zero/core/stores/redis"
	import {{.authImport}}
)

type Config struct {
	rest.RestConf
	{{.auth}}
	{{.jwtTrans}}
    MySQL struct {
		DSN             string
		LogMode         bool
		MaxOpenCons     int
		MaxIdleCons     int
		CreateBatchSize int
	}
	Kafka struct {
		Addr      string
		Topic     string
		Partition int
		BatchSize int
	}
	RedisConf redis.RedisConf
}
