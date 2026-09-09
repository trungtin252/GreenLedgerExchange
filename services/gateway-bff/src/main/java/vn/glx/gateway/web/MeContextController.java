package vn.glx.gateway.web;

import java.util.List;
import java.util.Map;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.glx.gateway.config.GatewayRuntimeProperties;

@RestController
@RequestMapping("/api/v1/me")
class MeContextController {
    private final GatewayRuntimeProperties runtime;

    MeContextController(GatewayRuntimeProperties runtime) {
        this.runtime = runtime;
    }

    @GetMapping("/context")
    MeContextResponse context(Authentication authentication) {
        var roles = authentication.getAuthorities().stream()
                .map(authority -> authority.getAuthority())
                .sorted()
                .toList();
        return new MeContextResponse(
                runtime.environment(),
                runtime.sandbox(),
                new Profile(authentication.getName(), authentication.getName()),
                roles,
                Map.of("registry.read", true, "exchange.read", true),
                List.of(),
                null);
    }

    record MeContextResponse(
            String environment,
            boolean sandbox,
            Profile profile,
            List<String> roles,
            Map<String, Boolean> capabilities,
            List<Organization> organizations,
            String activeOrganizationId) {}

    record Profile(String subject, String displayName) {}

    record Organization(String id, String displayName) {}
}
