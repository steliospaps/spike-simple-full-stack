package io.github.steliospaps.echo;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.web.reactive.function.BodyInserter;
import org.springframework.web.reactive.function.BodyInserters;

@ExtendWith(SpringExtension.class)
//We create a `@SpringBootTest`, starting an actual server on a `RANDOM_PORT`
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EchoControllerTest {
	@Autowired  
	private WebTestClient webTestClient;
	
	@Test
	void test() {
		webTestClient
	      // Create a GET request to test an endpoint
	      .post().uri("/echo")
	      .contentType(MediaType.APPLICATION_JSON)
	      .bodyValue(new EchoRequest("foo"))
	      .accept(MediaType.APPLICATION_JSON)
	      .exchange()
	      // and use the dedicated DSL to test assertions against the response
	      .expectStatus().isOk()
	      .expectBody(EchoResponse.class).isEqualTo(new EchoResponse("hello foo"));
	}

}
