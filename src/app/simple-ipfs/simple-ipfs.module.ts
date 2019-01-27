import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ImageUploadComponent } from './image-upload/image-upload.component';
import { SimpleIpfsService } from './simple-ipfs.service';
import { SimpleIpfsCallback } from './simple-ipfs-callback.interface';

@NgModule({
  declarations: [ImageUploadComponent],
  imports: [
    CommonModule
  ],
  exports:[
    ImageUploadComponent,
  ],
  providers: [
    SimpleIpfsService
  ]
})
export class SimpleIpfsModule { }
