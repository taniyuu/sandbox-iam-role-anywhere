package example.rolesanywhere;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import software.amazon.awssdk.services.s3.S3Client;

@RestController
public class BucketController {
    private final S3Client s3Client;

    public BucketController(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    @GetMapping("/buckets")
    public List<String> listBuckets() {
        return s3Client.listBuckets().buckets().stream()
                .map(bucket -> bucket.name())
                .toList();
    }
}