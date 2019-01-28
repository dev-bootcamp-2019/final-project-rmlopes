import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material';
import { BehaviorSubject } from 'rxjs';
import { SimpleIpfsCallback } from './simple-ipfs-callback.interface';

declare let require: any;
const ipfsAPI = require('ipfs-api');
const Buffer = require('buffer').Buffer;
        
@Injectable({
  providedIn: 'root'
})
export class SimpleIpfsService {

  private ipfs = ipfsAPI('ipfs.infura.io', '5001', {protocol: 'https'});
  private imgBuffer;
  private theHash;
  public newHash$ = new BehaviorSubject<string>('');

  constructor(private matSnackBar: MatSnackBar) { 
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 3000});
  }

  async addImage(caller: SimpleIpfsCallback){
    var reader = new FileReader();
    console.log(caller.imgPath);
    reader.readAsArrayBuffer(caller.imgPath);

    //this.setStatus("Uploading Image. Please wait...")
    reader.onload = async (_event) => { 
      this.imgBuffer = reader.result; 

      //var buffer = Buffer.from(imgBuffer);
      console.log("IPFS Service addImage " + this.imgBuffer);
      
      let testBuffer = new Buffer(this.imgBuffer);
      const results = await this.ipfs.files.add(testBuffer);
      //if error do something
      var imgHash = results[0].hash;
      console.log("New Image Hash:" + imgHash);
      //this.newHash$.next(imgHash);
      //window.dispatchEvent(new CustomEvent('hash-ready', {detail: [id, imgHash]}));
      caller.ipfsImageCallback(imgHash);
      //return imgHash;
    }
  }

  async getIpfsImage(caller: SimpleIpfsCallback){
    console.group("IPFS Service fetching "+caller.imgHash);
    this.ipfs.files.get('/ipfs/'+caller.imgHash, function (err, files) {
      if(err)
        console.log(err);
      else
        files.forEach((file) => {
          var arrayBufferView = new Uint8Array(file.content);
          var blob = new Blob( [ arrayBufferView ], { type: "image/jpeg" });
          //var blob = new Blob( [ arrayBufferView ]);
          
          var theurl = window.URL.createObjectURL(blob);
          console.log(theurl)
          //var decodedData = window.atob(file.content);
          //console.log(decodedData)
          //var blob = new Blob( [ arrayBufferView ], { type: “image/jpeg” } );
          caller.ipfsImageURLCallback(theurl);
        })
    })

  }
}
