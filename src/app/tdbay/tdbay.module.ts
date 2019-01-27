import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TdbayAdminComponent } from './tdbay-admin/tdbay-admin.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatOptionModule, MatSelectModule, MatSnackBarModule } from '@angular/material';
import { RouterModule } from '@angular/router';
import { UtilModule } from '../util/util.module';
import {DesignModule} from '../design/design.module';
import { TDBayService } from "./tdbay.service";

@NgModule({
  declarations: [TdbayAdminComponent],
  imports: [
    BrowserAnimationsModule,
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatOptionModule,
    MatSelectModule,
    MatSnackBarModule,
    DesignModule,
    RouterModule,
    UtilModule
  ],
  providers: [
    TDBayService
  ],
})
export class TDBayModule { }
