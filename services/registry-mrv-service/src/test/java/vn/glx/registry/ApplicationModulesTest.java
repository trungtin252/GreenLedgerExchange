package vn.glx.registry;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ApplicationModulesTest {
    @Test
    void verifiesModuleStructure() {
        ApplicationModules.of(RegistryMrvApplication.class).verify();
    }
}
