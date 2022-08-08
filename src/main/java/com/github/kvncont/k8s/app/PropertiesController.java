package com.github.kvncont.k8s.app;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PropertiesController {
    
    @Value("${db.url}")
    private String dbUrl;

    @Value("${db.user}")
    private String dbUser;

    @Value("${db.pass}")
    private String dbPass;

    @GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Object> index() {

        Map<String, String> map = new HashMap<>();
        map.put("dbURL", dbUrl);
        map.put("dbUser", dbUser);
        map.put("dbPass", dbPass);
		
        return new ResponseEntity<>(map, HttpStatus.OK);
	}
}
