def IsMsiGenRelated() {
    checkout scm
    try {
        sh "git status"
        sh "git log --graph"
        sh "git diff --name-only $CHANGE_TARGET..$CHANGE_BRANCH"
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