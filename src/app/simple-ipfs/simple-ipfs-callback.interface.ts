import { DomSanitizer, SafeUrl } from "@angular/platform-browser";

export abstract class SimpleIpfsCallback {
    public imgPath: any;
    public imgHash: string;
    protected imgURL: SafeUrl;
    protected imgInitialized: boolean;

    constructor(public sanitizer: DomSanitizer){
        this.imgInitialized = false;
    }

    abstract ipfsImageCallback(imgHash: string): void;
    
    ipfsImageURLCallback(imgURL){
        this.imgURL = this.sanitizer.bypassSecurityTrustUrl(imgURL);
        this.imgInitialized = true;
    }
}