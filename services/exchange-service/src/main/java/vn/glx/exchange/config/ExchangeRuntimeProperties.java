package vn.glx.exchange.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "glx.runtime")
public record ExchangeRuntimeProperties(String environment, boolean sandbox) {}
