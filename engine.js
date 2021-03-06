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
              '<option value="float" >Float</option>' + //
              '<option value="int">Integer</option>' + //
              '<option value="cate" >Categorical</option>' + //
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
    // getById("save-loader").style.display = "inline-block";
    var runner = document.querySelector('input[name="target-runner"]:checked').value;
    var parm_conf = getById('parameters-meta').value;

    var parm_prefix = parm_conf == "0" || parm_conf == "1" ? "--" : "-" ;
    var parm_sep    = parm_conf == "0" || parm_conf == "2" ? "=" : " " ;

    var parameters = getParmsInfo();

    var area = document.getElementById("instances-list");
    var lines = area.value.replace(/\r\n/g,"\n").split("\n");
    lines = lines.filter(function (el) {
      return el != "";
    });
    var project = {
        "project-name":          getById('project-name').value,
        "target-algorithm-src":  runner,
        "target-algorithm-name": getById('target-algorithm-name').value,
        "target-algorithm-path": getById('target-algorithm-path').value,
        "threads":               getById('distributed').value,
        "target-runner-calls":   Math.max(1, parseInt(getById('number-of-calls').value)),
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
    var fls  = ["--flag=value","--flag value","-flag=value","-flag value"] 
    for (var i = 0; i < items.length; i++) {
        var item = getById(items[i]);
        var aux = item.value;
        if (items[i] == "parameters-meta" ) {
            aux = fls[parseInt(aux)];
        }
        txt += " " + aux;
    }

    var v = getById(item_id);
    v.innerHTML = txt;
}

function projectToHTML(json){
    console.log(json);
    console.log(json["project-name"]);
    getById('project-name').value = json["project-name"];
    getById('target-algorithm-name').value = json["target-algorithm-name"];
    getById('target-algorithm-path').value = json["target-algorithm-path"];
    getById('distributed').value = json["threads"];
    getById('instance-flag').value = json["instance-flag"];
    getById('instance-path').value = json["instances-path"];
    getById('instance-file').value = json["instances-file"];
    getById("instances-list").value = json["instances"].join("\n");
    getById('number-of-calls').value = json["target-runner-calls"];

    var n = 0;
    if (json["parameters"]["prefix"] == "--" && json["parameters"]["sep"] == " ") {
        n = 1;
    }else if (json["parameters"]["prefix"] == "-" && json["parameters"]["sep"] == "=") {
        n = 2;
    }else if (json["parameters"]["prefix"] == "-" && json["parameters"]["sep"] == " ") {
        n = 3;
    }
    
    getById('parameters-meta').value = String(n);


    var parameters = json["parameters"]["parameters"];
    n = parameters.length;
    getById("number-of-parameters").value = String(n);
    gentable(n);
    for (var i = 0; i < n; i++) {
        getById("parm-name-" + i).value = parameters[i]["name"];
        getById("parm-flag-" + i).value = parameters[i]["flag"];
        getById("parm-type-" + i).value = parameters[i]["type"];
        getById("parm-values-" + i).value = parameters[i]["values"];
    }

    

    // var runner = document.querySelector('input[name="target-runner"]:checked').value;

    // var parameters = getParmsInfo();

    // var area = document.getElementById("instances-list");
    // var lines = area.value.replace(/\r\n/g,"\n").split("\n");
    // var project = {
    //     "target-algorithm-src":  runner,
    //     "parameters": {
    //         "parameters": parameters
    //     },
    //     "instances": lines
    // };
}


function goto(str){
    if (str == "projects") {
        Blink.msg('gotoProjects', str);
    }
}

function nextTab(i){
    var tabs = getById("tabs");
    var instance = M.Tabs.getInstance(tabs);
    var str = "step" + (instance.index + 1 + i);
    console.log(str);
    instance.select(str);

    if (instance.index < 1) {
        getById("back-btn").style.display = "none";
    }else{
        getById("back-btn").style.display = "inline-block";
    }
}