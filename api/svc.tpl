package svc

import (
	"database/sql"
	"github.com/redis/go-redis/v9"
	"github.com/segmentio/kafka-go"
	"github.com/zeromicro/go-zero/rest"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"gorm.io/gorm/schema"
	"log"
	"time"
	"zero-chat/api/internal/config"
	"zero-chat/api/internal/middleware"
	"zero-chat/api/internal/model"
)

type ServiceContext struct {
	Config       config.Config
	Authority    rest.Middleware
	Redis        *redis.Client
	DB           *gorm.DB
	KafkaReader  *kafka.Reader
	KafkaWriter  *kafka.Writer
}

func NewServiceContext(c config.Config) *ServiceContext {
	db := Init(c)
	rds := InitRedis(c)
	return &ServiceContext{
		Config:       c,
		Authority:    middleware.NewAuthorityMiddleware(c.Auth.AccessSecret).Handle,
		Redis:        rds,
		DB:           db,
		KafkaReader:  InitKafkaReader(c),
		KafkaWriter:  InitKafkaWriter(c),
	}
}

func InitKafkaWriter(c config.Config) *kafka.Writer {
	return &kafka.Writer{
		Addr:                   kafka.TCP(c.Kafka.Addr),
		Topic:                  c.Kafka.Topic,
		Balancer:               &kafka.Hash{},
		WriteTimeout:           1 * time.Second,
		RequiredAcks:           kafka.RequireNone,
		AllowAutoTopicCreation: true, // 一般交由运维管理，即实际开发应该是false
	}
}
func InitKafkaReader(c config.Config) *kafka.Reader {
	return kafka.NewReader(kafka.ReaderConfig{
		Brokers:        []string{c.Kafka.Addr},
		Topic:          c.Kafka.Topic,
		CommitInterval: 1 * time.Second, // 隔一段时间提交offset
		//GroupID:        "group_id",
		StartOffset: kafka.FirstOffset, // 新的consumer从最开始的，消息开始消费，仅对刚开始有效
	})
}

func Init(c config.Config) (db *gorm.DB) {
	var (
		sqlDB *sql.DB
		err   error
	)
	mysqlConf := mysql.Config{DSN: c.MySQL.DSN}

	gormConfig := configLog(c.MySQL.LogMode)
	if db, err = gorm.Open(mysql.New(mysqlConf), gormConfig); err != nil {
		log.Fatal("opens database failed: ", err)
	}
	if sqlDB, err = db.DB(); err != nil {
		log.Fatal("db.db() failed: ", err)
	}

	sqlDB.SetMaxIdleConns(c.MySQL.MaxIdleCons)
	sqlDB.SetMaxOpenConns(c.MySQL.MaxOpenCons)
	return
}

func InitRedis(c config.Config) (rds *redis.Client) {
	return redis.NewClient(&redis.Options{
		Addr:     c.RedisConf.Host,
		Password: c.RedisConf.Pass,
		DB:       0,
	})

}

// configLog 根据配置决定是否开启日志
func configLog(mod bool) (c *gorm.Config) {
	if mod {
		c = &gorm.Config{
			Logger:                                   logger.Default.LogMode(logger.Info),
			DisableForeignKeyConstraintWhenMigrating: true,
			NamingStrategy: schema.NamingStrategy{
				SingularTable: true, // 表名不加复数形式，false默认加
			},
		}
	} else {
		c = &gorm.Config{
			Logger:                                   logger.Default.LogMode(logger.Silent),
			DisableForeignKeyConstraintWhenMigrating: true,
			NamingStrategy: schema.NamingStrategy{
				SingularTable: true, // 表名不加复数形式，false默认加
			},
		}
	}
	return
}
