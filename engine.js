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
            '<input id="parm-name-'+i+'" type="text" class="validate">' + //
            '<label for="parm-name-'+i+'">Name</label>' + //
        '</div>' + //
    '</td>' + //
    '<td>' + //
        '<div class="input-field">' + //
            '<input id="parm-flag-'+i+'" type="text" class="validate">' + //
            '<label for="parm-flag-'+i+'">Flag</label>' + //
        '</div>' + //
    '</td>' + //
    '<td>' + //
        '<div class="input-field col s12">' + //
            '<select id="parm-type-'+ i +'">' + //
              '<option value="float" selected>Float</option>' + //
              '<option value="int">Integer</option>' + //
              '<option value="cate" selected>Categorical</option>' + //
              '<option value="bool">Boolean</option>' + //
            '</select>' + //
            '<label>Type</label>' + //
        '</div>' + //
    '</td>' + //
    '<td>' + //
        '<div class="input-field">' + //
            '<input id="parm-values-'+i+'" type="text" class="validate">' + //
            '<label for="parm-values-'+i+'">Values</label>' + //
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

function getById(s){
    return document.getElementById(s);
}

function getParmsInfo(){
    var n = parseInt(getById("number-of-parameters").value);
    let parms = []
    for (var i = 0; i < n; i++) {
        var name = getById("parm-name-" + i).value;
        var flag = getById("parm-flag-" + i).value;
        var type = getById("parm-type-" + i).value;
        var values = getById("parm-values-" + i).value;

        parms.push(
            {"flag": flag,
             "name": name,
             "type": type,
             "values": values}
            );

    }

    return parms;
}



function saveValues(){
    var runner = document.querySelector('input[name="target-runner"]:checked').value;
    var parm_conf = getById('parameters-meta').value;

    var parm_prefix = parm_conf == "0" || parm_conf == "1" ? "--" : "-" ;
    var parm_sep    = parm_conf == "0" || parm_conf == "2" ? "=" : " " ;

    var parameters = getParmsInfo();

    var area = document.getElementById("instances-list");
    var lines = area.value.replace(/\r\n/g,"\n").split("\n");
    var project = {
        "project-name":          getById('project-name').value,
        "target-algorithm-src":  runner,
        "target-algorithm-name": getById('target-algorithm-name').value,
        "target-algorithm-path": getById('target-algorithm-path').value,
        "threads":               getById('distributed').value,
        "parameters": {
            "prefix": parm_prefix,
            "sep":    parm_sep,
            "parameters": parameters
        },
        "instance-flag":  getById('instance-flag').value,
        "instances-path": getById('instance-path').value,
        "instances-file": getById('instance-file').value,
        "instances": lines
    };

    Blink.msg("saveProject", project)
    console.log(project);

}

function removeProject(json_name, str){

    confirm("Remove project "  + str + "?") ? Blink.msg('removeProject', json_name) : 0;
}

function chooseTargetProgram(){
    Blink.msg('chooseTargetProgram', "json_name");
}

function chooseFile(str){
    Blink.msg('chooseFile', str);

}

function chooseDirectory(str){
    Blink.msg('chooseDirectory', str);

}

function updateCMDExample(item_id, items){
    var txt = "";
    for (var i = 0; i < items.length; i++) {
        var item = getById(items[i]);
        txt += " " + item.value;
    }

    var v = getById(item_id);
    v.innerHTML = txt;
}