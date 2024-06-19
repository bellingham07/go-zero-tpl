package {{.PkgName}}

import (
    "github.com/HiBugEnterprise/gotools/errorx"
	"github.com/HiBugEnterprise/gotools/httpc"
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"

	{{.ImportPackages}}
)

func {{.HandlerName}}(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		{{if .HasRequest}}var req types.{{.RequestType}}
		if err := httpx.Parse(r, &req); err != nil {
            httpc.RespError(w, r, errorx.BadRequest("%s:%s", errorx.CodeInvalidParams.Msg(), err.Error()).Show())
			return
		}
		{{end}}l := {{.LogicName}}.New{{.LogicType}}(r.Context(), svcCtx)
		{{if .HasResp}}resp, {{end}}err := l.{{.Call}}({{if .HasRequest}}&req{{end}})
		if err != nil {
			httpc.RespError(w, r, err)
		} else {
			{{if .HasResp}}httpc.RespSuccess(r.Context(), w, resp){{else}}httpc.RespSuccess(r.Context(), w, nil){{end}}
		}
	}
}
