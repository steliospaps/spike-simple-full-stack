package io.github.steliospaps.echo;

import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;

@RestController
@Slf4j
public class EchoController {
	{
		log.info("created!");
	}
	
	@RequestMapping(path = "/echo" , method = RequestMethod.POST)
	public Mono<EchoResponse> echo(@RequestBody EchoRequest request) {
		log.info("got {}",request);
		return Mono.just(new EchoResponse("hello "+request.getRequest()));
	}
}
