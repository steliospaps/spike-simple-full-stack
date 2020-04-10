package io.github.steliospaps.echo;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;

@CrossOrigin //TODO: dont use this in prod like this
@RestController
@Slf4j
public class EchoController {

	@RequestMapping(path = "/echo" , method = RequestMethod.POST)
	public Mono<EchoResponse> echo(@RequestBody EchoRequest request) {
		log.info("got {}",request);
		return Mono.just(new EchoResponse("hello "+request.getRequest()));
	}
}
