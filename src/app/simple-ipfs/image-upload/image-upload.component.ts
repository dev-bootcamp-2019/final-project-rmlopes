import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { MatSnackBar } from '@angular/material';

@Component({
  selector: 'app-image-upload',
  templateUrl: './image-upload.component.html',
  styleUrls: ['./image-upload.component.css']
})
export class ImageUploadComponent implements OnInit {

  private imgURL;
  private imagePath;
  @Output() imgLoaded = new EventEmitter<{}>();;

  constructor(private matSnackBar: MatSnackBar) { }

  ngOnInit() {
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 3000});
  }

  preview(files) {
    if (files.length === 0)
      return;
 
    var mimeType = files[0].type;
    if (mimeType.match(/image\/*/) == null) {
      this.setStatus("Only images are supported.");
      return;
    }
 
    var reader = new FileReader();
    this.imagePath = files;
    reader.readAsDataURL(files[0]); 
    reader.onload = (_event) => { 
      this.imgURL = reader.result; 
      this.imgLoaded.emit(this.imagePath[0]);
    }
  }

}
