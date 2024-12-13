#!groovy

def days = 5

stage("Get RFC stages stats") {
    podTemplate (cloud: 'kubernetes', yaml: readTrusted('nodes/metricsPodTemplateDefinition')) {
        retry(count: 2, conditions: [kubernetesAgent(), nonresumable()]) {
            node() {
                withCredentials([usernamePassword(credentialsId: '7-League-API-Query', usernameVariable: 'USER_NAME', passwordVariable: 'API_TOKEN')]) {
                    checkout scm
                    sh 'DAYS_OLD=${days} BEE-42296/build_time_metrics.sh'
                    archiveArtifacts artifacts: 'stages.csv'
                 }
            }
        }
    }
}