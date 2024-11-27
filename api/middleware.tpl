package middleware

import (
	"github.com/bellingham07/go-tool/codex"
	"github.com/bellingham07/go-tool/errorx"
	"github.com/bellingham07/go-tool/httpc"
	"github.com/zeromicro/go-zero/rest/handler"
	"net/http"
)

type AuthorityMiddleware struct {
	Secret string
}

func NewAuthorityMiddleware(secret string) *AuthorityMiddleware {
	return &AuthorityMiddleware{
		Secret: secret,
	}
}

func (m *{{.name}})Handle(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// TODO you can change the authorization method in there
        // 获取用户token
		tokenLength := len(r.Header.Get("Authorization"))
		if tokenLength < 0 {
			err := errorx.New("ParamErr", int(codex.CodeInvalidToken), codex.CodeInvalidToken.Msg())
			httpc.RespError(w, r, err)
			return
		}
		authHandler := handler.Authorize(m.Secret)
		authHandler(next).ServeHTTP(w, r)
		return
	}
}
