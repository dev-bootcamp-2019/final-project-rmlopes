import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { OwnerProjectListComponent } from './owner-project-list.component';

describe('OwnerProjectListComponent', () => {
  let component: OwnerProjectListComponent;
  let fixture: ComponentFixture<OwnerProjectListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ OwnerProjectListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(OwnerProjectListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
