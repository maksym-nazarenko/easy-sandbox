import jenkins.model.*
import hudson.security.*

import jenkins.security.QueueItemAuthenticatorConfiguration
import org.jenkinsci.plugins.authorizeproject.ProjectQueueItemAuthenticator
import org.jenkinsci.plugins.authorizeproject.strategy.AnonymousAuthorizationStrategy
import org.jenkinsci.plugins.authorizeproject.strategy.SpecificUsersAuthorizationStrategy
import org.jenkinsci.plugins.authorizeproject.strategy.SystemAuthorizationStrategy
import org.jenkinsci.plugins.authorizeproject.strategy.TriggeringUsersAuthorizationStrategy

String adminUsername = System.getenv("ADMIN_USERNAME")
String adminPassword = System.getenv("ADMIN_PASSWORD")

assert adminUsername != null : "No ADMIN_USERNAME env variable found"
assert adminPassword != null : "No ADMIN_PASSWORD env variable found"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.securityRealm = hudsonRealm

authorizationStrategy = new GlobalMatrixAuthorizationStrategy();
authorizationStrategy.add(Jenkins.ADMINISTER, adminUsername)
Jenkins.instance.authorizationStrategy = authorizationStrategy


def authenticators = QueueItemAuthenticatorConfiguration.get().authenticators

def configure = true
for (auth in authenticators) {
    if (!(auth instanceof ProjectQueueItemAuthenticator)) {
        configure = false
        break
    }
}

if (configure) {
    def strategies = [:]
    Jenkins.instance.with {
        instance
        strategies = [
                (instance.getDescriptor(AnonymousAuthorizationStrategy.class).getId())      : true,
                (instance.getDescriptor(TriggeringUsersAuthorizationStrategy.class).getId()): true,
                (instance.getDescriptor(SpecificUsersAuthorizationStrategy.class).getId())  : true,
                (instance.getDescriptor(SystemAuthorizationStrategy.class).getId())         : false
        ]
    }
    authenticators.add(new ProjectQueueItemAuthenticator(strategies))
}

Jenkins.instance.save()
