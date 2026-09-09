package vn.glx.exchange;

import static org.assertj.core.api.Assertions.assertThat;

import javax.sql.DataSource;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.NONE,
        properties = "glx.security.jwt.enabled=false")
class FoundationMigrationIT {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:18.0");

    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry properties) {
        properties.add("spring.datasource.url", postgres::getJdbcUrl);
        properties.add("spring.datasource.username", postgres::getUsername);
        properties.add("spring.datasource.password", postgres::getPassword);
        properties.add("spring.flyway.user", postgres::getUsername);
        properties.add("spring.flyway.password", postgres::getPassword);
    }

    @Autowired
    Flyway flyway;

    @Autowired
    DataSource dataSource;

    @Test
    void applicationStartupMigratesExchangeFoundation() throws Exception {
        assertThat(flyway.info().current().getVersion().getVersion()).isEqualTo("001");
        try (var connection = dataSource.getConnection();
                var statement = connection.prepareStatement("select count(*) from job_execution")) {
            var result = statement.executeQuery();
            result.next();
            assertThat(result.getInt(1)).isZero();
        }
    }
}
