function main(){
    Blink.msg("press2", "HELLO 2");

}

function createProject(){
    var name = document.getElementById('project-name').value;
    
    var target_runner = document.querySelector('input[name="target-runner"]:checked').value;
    var distributed = document.querySelector('#distributed').checked;


    Blink.msg("createProject", [name,target_runner,distributed]);
        

    console.log(name);
    console.log(target_runner);
    console.log(distributed);
}
