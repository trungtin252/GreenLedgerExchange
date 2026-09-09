package vn.glx.registry.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "glx.runtime")
public record RegistryRuntimeProperties(String environment, boolean sandbox) {}
