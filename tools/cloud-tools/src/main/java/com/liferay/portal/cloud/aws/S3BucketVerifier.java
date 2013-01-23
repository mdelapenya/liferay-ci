package com.liferay.portal.cloud.aws;

import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ListVersionsRequest;
import com.amazonaws.services.s3.model.S3VersionSummary;
import com.amazonaws.services.s3.model.VersionListing;

public class S3BucketVerifier {

	public S3BucketVerifier(String identity, String secretKey) {
		AWSCredentials awsCredentials = new BasicAWSCredentials(identity,
				secretKey);
		S3BucketVerifier.amazonS3 = new AmazonS3Client(awsCredentials);
	}

	public void verifyAndRepair(final String bucket) {
		ListVersionsRequest listVersionsRequest = new ListVersionsRequest()
				.withBucketName(bucket);

		final ExecutorService executorService = Executors
				.newFixedThreadPool(30);

		VersionListing versionListing = this.amazonS3
				.listVersions(listVersionsRequest);

		do {
			List<S3VersionSummary> versionSummaries = versionListing
					.getVersionSummaries();

			final CountDownLatch countDownLatch = new CountDownLatch(
					versionSummaries.size());

			for (final S3VersionSummary s3VersionSummary : versionSummaries) {
				executorService.execute(new Runnable() {

					@Override
					public void run() {
						try {
							amazonS3.deleteVersion(bucket,
									s3VersionSummary.getKey(),
									s3VersionSummary.getVersionId());
						} finally {
							countDownLatch.countDown();
						}
					}
				});
			}

			try {
				// Wait to all the previous tasks to be finished in order to
				// prevent over populating the thread pool
				countDownLatch.await();
			} catch (InterruptedException e) {
			}

			versionListing = this.amazonS3
					.listNextBatchOfVersions(versionListing);
		} while (versionListing.isTruncated());

		executorService.shutdown();
	}

	private static AmazonS3 amazonS3;

	public static void main(String[] args) {
		if (args.length != 3) {
			throw new IllegalArgumentException(
					"Invalid number of parameters. Syntax is: \"identity\" \"secretKey\" \"container\"");
		}

		String identity = args[0];
		String secretKey = args[1];
		String bucket = args[2];

		S3BucketVerifier s3BucketVerifier = new S3BucketVerifier(identity,
				secretKey);

		s3BucketVerifier.verifyAndRepair(bucket);
	}
}
