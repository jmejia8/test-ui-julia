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


function genrow(i){
    var txt = '<tr>' + //
    '<td>' + (i+1) + '</td>' + //
    '<td>' + //
        '<div class="input-field">' + //
            '<input id="target-runner-name'+i+'" type="text" class="validate">' + //
            '<label for="project-name">Name</label>' + //
        '</div>' + //
    '</td>' + //
    '<td>' + //
        '<div class="input-field">' + //
            '<input id="target-runner-app-'+i+'" type="text" class="validate">' + //
            '<label for="project-name">Flag</label>' + //
        '</div>' + //
    '</td>' + //
    '<td>' + //
        '<div class="input-field col s12">' + //
            '<select>' + //
              '<option value="" selected>Float</option>' + //
              '<option value="1">Integer</option>' + //
              '<option value="2" selected>Categorical</option>' + //
              '<option value="3">Boolean</option>' + //
            '</select>' + //
            '<label>Type</label>' + //
        '</div>' + //
    '</td>' + //
    '<td>' + //
        '<div class="input-field">' + //
            '<input id="parameters'+i+'" type="text" class="validate">' + //
            '<label for="project-name">Values</label>' + //
        '</div>' + //
    '</td>' + //
  '</tr>'
  return txt
}

function gentable(n){
    var table = document.getElementById('tab-parms');
    n = parseInt(n);

    var txt  = "";
    for (var i = 0; i < n; i++) {
        txt += genrow(i)
    }

    table.innerHTML = txt;

  M.AutoInit();

}