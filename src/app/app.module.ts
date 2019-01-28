import { BrowserModule } from '@angular/platform-browser';
import { NgModule, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import {ProjectsModule} from './projects/projects.module';
import {TDBayModule} from './tdbay/tdbay.module';
import {SimpleIpfsModule} from './simple-ipfs/simple-ipfs.module';
import { CommonModule } from '@angular/common';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import {
  MatButtonModule,
  MatCardModule,
  MatFormFieldModule,
  MatInputModule,
  MatToolbarModule,
  MatIconModule,
  MatMenuModule
} from '@angular/material'

import { ProjectListingComponent } from './projects/project-listing/project-listing.component';
import { TdbayAdminComponent } from './tdbay/tdbay-admin/tdbay-admin.component';
import { DesignListingComponent } from './design/design-listing/design-listing.component';
import { OwnerProjectListComponent } from './projects/owner-project-list/owner-project-list.component';

const appRoutes: Routes = [
  { path: 'tdbay-admin', component: TdbayAdminComponent },
  { path: 'projects',      component: ProjectListingComponent },
  { path: 'designs',      component: DesignListingComponent },
  { path: 'owner-projects',      component: OwnerProjectListComponent },
];

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserAnimationsModule,
    CommonModule,
    MatButtonModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatToolbarModule,
    BrowserModule,
    FormsModule,
    HttpClientModule,
    ProjectsModule,
    TDBayModule,
    MatToolbarModule,
    MatIconModule,
    MatMenuModule,
    SimpleIpfsModule,
    RouterModule.forRoot(
      appRoutes,
      { enableTracing: true } // <-- debugging purposes only
    )
  ],
  exports: [],
  providers: [],
  bootstrap: [AppComponent]
})

export class AppModule{ 
}
