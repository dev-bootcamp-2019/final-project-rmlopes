import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DesignAdminComponent } from './design-admin.component';

describe('DesignAdminComponent', () => {
  let component: DesignAdminComponent;
  let fixture: ComponentFixture<DesignAdminComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DesignAdminComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DesignAdminComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
