pipeline {
    agent { label 'podman' }

    options {
        disableConcurrentBuilds()
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        REGISTRY = 'registry.assign.tdnguyen51.300.ops:5000'
        IMAGE_NAME = 'bind-secondary'
    }

    stages {
        stage('Check agent') {
            steps {
                sh '''
                    hostname
                    whoami
                    podman --version
                    test -f Dockerfile
                '''
            }
        }

        stage('Build image') {
            steps {
                sh '''
                    podman build -f Dockerfile \
                      -t "$REGISTRY/$IMAGE_NAME:$BUILD_NUMBER" .
                '''
            }
        }

        stage('Login and push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'registry-auth',
                    usernameVariable: 'REGISTRY_USER',
                    passwordVariable: 'REGISTRY_PASSWORD'
                )]) {
                    sh '''
                        set +x
                        set -eu
                        authdir=$(mktemp -d)
                        trap 'rm -rf "$authdir"' EXIT

                        printf '%s' "$REGISTRY_PASSWORD" |
                          podman login \
                            --authfile "$authdir/auth.json" \
                            --username "$REGISTRY_USER" \
                            --password-stdin "$REGISTRY"

                        podman push \
                          --authfile "$authdir/auth.json" \
                          "$REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"
                    '''
                }
            }
        }
    }
}
