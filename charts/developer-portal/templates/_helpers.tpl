{{/*
Expand the name of the chart.
*/}}
{{- define "developer-portal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "developer-portal.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "developer-portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "developer-portal.labels" -}}
helm.sh/chart: {{ include "developer-portal.chart" . }}
{{ include "developer-portal.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "developer-portal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "developer-portal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Fully qualified name for the in-cluster postgres instance.
*/}}
{{- define "developer-portal.postgresName" -}}
{{- printf "%s-postgres" (include "developer-portal.fullname" .) }}
{{- end }}

{{/*
Postgres host: in-cluster service when postgres.enabled, otherwise the configured external host.
*/}}
{{- define "developer-portal.postgresHost" -}}
{{- if .Values.postgres.enabled }}
{{- include "developer-portal.postgresName" . }}
{{- else }}
{{- required "postgres.host is required when postgres.enabled is false" .Values.postgres.host }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "developer-portal.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "developer-portal.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
