def IsMsiGenRelated() {
    checkout scm
    try {
        sh 'git remote -v'
        sh 'git branch -a'
        sh 'git log --graph "origin/$CHANGE_TARGET"'
        sh 'git log --graph "HEAD"'
        sh 'git diff --name-only "origin/$CHANGE_TARGET"..HEAD | grep -e "msi.py" -e "unified-release/dist/unified-distribution/scons/resources/msi/*"'
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