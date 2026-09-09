package vn.glx.gateway.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.TestingAuthenticationToken;
import vn.glx.gateway.config.GatewayRuntimeProperties;

class GatewayBffApplicationTests {
    @Test
    void authenticatedContextIncludesOnlyCoarseSessionInformation() {
        var controller = new MeContextController(new GatewayRuntimeProperties("local", true));
        var authentication = new TestingAuthenticationToken("demo-user", "ignored", "ROLE_GLX_VIEWER");

        var context = controller.context(authentication);

        assertThat(context.environment()).isEqualTo("local");
        assertThat(context.sandbox()).isTrue();
        assertThat(context.profile().subject()).isEqualTo("demo-user");
        assertThat(context.roles()).containsExactly("ROLE_GLX_VIEWER");
        assertThat(context.activeOrganizationId()).isNull();
    }
}
