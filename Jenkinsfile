def IsMsiGenRelated() {
    checkout scm
    try {
        sh 'git diff --name-only "${CHANGE_TARGET}"..HEAD'
        return true
    }
    catch(Exception e) {
        return false
    }
    // Should never happen    
    return false
}

node(){
    if (IsMsiGenRelated()) {
        sh 'echo true'
    }
}