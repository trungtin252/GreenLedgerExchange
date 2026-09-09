package vn.glx.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "glx.runtime")
public record GatewayRuntimeProperties(String environment, boolean sandbox) {}
