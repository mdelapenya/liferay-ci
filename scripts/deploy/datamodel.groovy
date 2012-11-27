#!/usr/bin/env groovy

/**
* This scripts checks if the upgrade*.sql file or the UpgradeProcess*.java
* differs from the current ones deployed.
* 
* If some change is found, the script will fail. The changes should be applied
* manually
*/

import java.security.MessageDigest

import static groovy.io.FileType.*
import static groovy.io.FileVisitResult.*

if (this.args.length != 3) {
	println "Usage: datamodel.groovy <Path to release.properties file><Path to staging portal-impl.jar><Path to the current deployed portal-impl.jar>"

	return
}

// release properties

determineCurrentVersion = { releaseFile ->
	def releaseProperties = new Properties()

	new File(releaseFile).withInputStream { 
 		stream -> releaseProperties.load(stream) 
	}	

	releaseProperties['lp.version']
}

def generateMD5 = { final inputStream ->

   MessageDigest digest = MessageDigest.getInstance("MD5")

	byte[] buffer = new byte[8192]
   	int read = 0

	while( (read = inputStream.read(buffer)) > 0) {
		digest.update(buffer, 0, read);
	}

   	def md5sum = digest.digest()

   	def bigInt = new BigInteger(1, md5sum)

   	bigInt.toString(16)
}



def extractTextFromZipFile = { zipFilePath, pattern , conversion ->
	def zipFile = new java.util.zip.ZipFile(zipFilePath)

	def md5sum

	zipFile.entries().find { pattern.matcher(it.name).matches() }.each {
		md5sum = conversion(zipFile.getInputStream(it))
	}

	md5sum
}

def currentVersion = determineCurrentVersion(args[0])

def portalImplStaging = new File(args[1])
def portalImplDeployed = new File(args[2])

new File("attachments").eachFile() { file ->
	file.delete();
}

def output = new File("attachments", "datamodel.status")

def error = false

[~/.*${currentVersion}\.sql/, ~/.*${currentVersion}\.class/].each { pattern ->

	stagedMD5 = extractTextFromZipFile(portalImplStaging, pattern, generateMD5)	

	deployedMD5 = extractTextFromZipFile(portalImplDeployed, pattern, generateMD5)	

	if(stagedMD5 != deployedMD5) {
		output << """[FAILURE]: Some of the files mathing the expression "${pattern}" have changed. Review it  and apply the changes by hand in your database!!\n"""

		error = true
	} else {
		output << """[SUCCESS]: No changes found in the files mathing the expression "${pattern}"!!\n"""
	}
}

if (error) throw new RuntimeException("The data model has changed and cannot be applied automatically") else println "No datamodel changes have been found"