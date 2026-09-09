package vn.glx.exchange;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ApplicationModulesTest {
    @Test
    void verifiesModuleStructure() {
        ApplicationModules.of(ExchangeApplication.class).verify();
    }
}
