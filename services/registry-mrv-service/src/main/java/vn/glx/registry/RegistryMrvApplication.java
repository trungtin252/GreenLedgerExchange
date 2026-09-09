package vn.glx.registry;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class RegistryMrvApplication {
    public static void main(String[] args) {
        SpringApplication.run(RegistryMrvApplication.class, args);
    }
}
