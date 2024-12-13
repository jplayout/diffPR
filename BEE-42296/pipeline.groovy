#!groovy

def days = 5

stage("Get RFC stages stats") {
            node() {
                withCredentials([usernamePassword(credentialsId: '7-League-API-Query', usernameVariable: 'USER_NAME', passwordVariable: 'API_TOKEN')]) {
                    checkout scm
                    sh 'DAYS_OLD=${days} BEE-42296/build_time_metrics.sh'
                    archiveArtifacts artifacts: 'stages.csv'
                 }
    }
}