{{- define "check.pem" -}}
{{- if not (regexMatch .pattern (.content | trim)) }}
  {{- fail (printf "TLS file %s is not a valid PEM, check format" .path) }}
{{- end }}
{{- end }}
