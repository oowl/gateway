admin:
  access_log:
  - name: envoy.access_loggers.file
    typed_config:
      "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
      path: {{ .AdminServer.AccessLogPath }}
  address:
    socket_address:
      address: {{ .AdminServer.Address }}
      port_value: {{ .AdminServer.Port }}
dynamic_resources:
  ads_config:
    api_type: DELTA_GRPC
    transport_api_version: V3
    grpc_services:
    - envoy_grpc:
        cluster_name: xds_cluster
    set_node_on_first_message_only: true
  lds_config:
    ads: {}
  cds_config:
    ads: {}
static_resources:
  clusters:
  - connect_timeout: 10s
    load_assignment:
      cluster_name: xds_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: {{ .XdsServer.Address }}
                port_value: {{ .XdsServer.Port }}
    typed_extension_protocol_options:
      "envoy.extensions.upstreams.http.v3.HttpProtocolOptions":
         "@type": "type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions"
         "explicit_http_config":
           "http2_protocol_options": {}
    name: xds_cluster
    type: STRICT_DNS
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          tls_params:
            tls_maximum_protocol_version: TLSv1_3
          tls_certificate_sds_secret_configs:
          - name: xds_certificate
            sds_config:
              path_config_source:
                path: "/sds/xds-certificate.json"
              resource_api_version: V3
          validation_context_sds_secret_config:
            name: xds_trusted_ca
            sds_config:
              path_config_source:
                path: "/sds/xds-trusted-ca.json"
              resource_api_version: V3
layered_runtime:
  layers:
  - name: runtime-0
    rtds_layer:
      rtds_config:
        ads: {}
      name: runtime-0
