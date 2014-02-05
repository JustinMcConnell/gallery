image_upload = {
  settings : {
    max_size : 150
  },
  preview_selector: "#image_preview",
  queue: []
}

/*
 * User added files from a file input.
 */
function add_file_from_computer(event) {
  preview_files(event.target.files);
}


/*
 * Display a preview of images that the user added to the upload page.
 */
function preview_files(file_list) {
  for (var i = file_list.length - 1; i >= 0; i--) {
    var reader = new FileReader();
    $(reader).on("loadend", function(event) {
      add_preview_image_and_resize(event.target.result)
    });
    reader.readAsDataURL(file_list[i]);
    image_upload.queue.push(file_list[i]);
  };
}


/*
 * Take an image URL and disp
 */
function add_preview_image_and_resize(url) {
  var last_preview = add_preview_image(url);
  window.setTimeout(function() {
    resize_preview_image(last_preview);
  }, 1);
}


/*
 * Add an image to the screen.
 */
function add_preview_image(url) {
  var preview = $(image_upload.preview_selector);
  var preview_count = preview.children().length + 1;
  preview.append("<li><img id='preview" + preview_count + "' src='" + url + "'></li>");
  return preview.find("#preview" + preview_count);
}


/*
 * Resize an image that is already on the screen
 */
function resize_preview_image(last_preview) {
  var old_height = parseInt(last_preview.css("height")),
      old_width = parseInt(last_preview.css("width")),
      new_height = image_upload.settings.max_size,
      new_width = Math.round(old_width / old_height * new_height);
  console.log("%d x %d -- %d x %d", old_width, old_height, new_width, new_height);
  last_preview.css("width", new_width + "px").css("height", new_height + "px");
}


/*
 * Take a URL the user has entered and add it to the preview area.
 */
function download_image_and_preview(url) {
  get_url_as_blob(url, function(blob) {
    image_upload.queue.push(blob);
    var object_url = window.URL.createObjectURL(blob);
    add_preview_image_and_resize(object_url);
    window.URL.revokeObjectURL(object_url);
  });
}


/*
 * Give a URL, get back a blob.
 */
function get_url_as_blob(url, callback) {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", url, true);
  xhr.responseType = "blob";
  xhr.onload = function(event) {
    if (this.status == 200) {
      callback(this.response);
    }
  };
  xhr.onerror = function(event) {
    console.log("Error " + event.target.status + " while trying to transfer " + url);
  }
  xhr.send();
}


/*
 * Functions to handle drag and drop file addition
 */
function drag_enter(event) {
  console.log("Drag enter");
  $(this).addClass("drag_enter");
  event.preventDefault();
}

function drag_leave(event) {
  console.log("Drag leave");
  $(this).removeClass("drag_enter");
  event.preventDefault();
}

function drag_over(event) {
  event.preventDefault();
}

function on_drop(event) {
  console.log("Drop");
  event.preventDefault();
  preview_files(event.dataTransfer.files);
  $(this).removeClass("drag_enter");
}


/*
 * Upload all files the user has added to the page
 */
function upload_files(form) {
  console.log("Sending form: %o", form);

  // clear file input to avoid duplicates
  form.elements["image[name][]"].value = "";

  // send files in queue
  for (var i=0, ic=image_upload.queue.length; i<ic; i++) {
    send_file(image_upload.queue[i], form, i);
  }

  // clear file queue
  image_upload.queue = [];
}


/*
 * Upload a single file
 */
function send_file(file, form, index) {
  var fd = new FormData(form);
  fd.append("image[name]", file);
  console.log("Sending " + file.original_name);

  add_progress_tag(index + 1);

  // send
  var xhr = new XMLHttpRequest();
  xhr.onload = function(event) {
    send_file_load(event, index);
  };
  xhr.onprogress = function(event) {
    send_file_progress(event, index);
  };
  xhr.open("POST", form.action + ".js", true);

  //xhr.setRequestHeader("Content-type", file.type);
  //xhr.setRequestHeader("X_FILE_NAME", file.name);
  //xhr.setRequestHeader("X-CSRF-Token", $("meta[name=csrf-token]").attr("content"));
  xhr.send(fd);  
}

function send_file_load(event, index) {
  if (event.target.status == 200) {
    console.log("Sent form");
    console.log(event.target.response);
    update_progress_tag(index + 1, 100);
  } else {
    console.log("Error " + event.target.status + " while sending form");
  }
}

function send_file_progress(event, index) {
  console.log("Progress %o", event);
  console.log(event.lengthComputable + " -- " + event.loaded + " -- " + event.total);
}

function add_progress_tag(index) {
  $("#preview" + index).after("<progress id='progress" + index + "' value='0' max='100'></progress>"); 
}
function update_progress_tag(index, value) {
  $("#progress" + index).attr("value", value);
}


$(document).ready(function() {
  document.documentElement.addEventListener("dragenter", drag_enter);
  document.documentElement.addEventListener("dragover", drag_over);
  document.documentElement.addEventListener("dragleave", drag_leave);
  document.documentElement.addEventListener("drop", on_drop);
  $("#image_url").on("change", function(event) {
    download_image_and_preview(event.target.value)
  });
  $("#new_image").on("submit", function(event) {
    console.log("submit");
    event.preventDefault();
    upload_files(this);
  });
});
