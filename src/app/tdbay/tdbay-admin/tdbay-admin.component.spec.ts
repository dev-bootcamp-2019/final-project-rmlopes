import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TdbayAdminComponent } from './tdbay-admin.component';

describe('TdbayAdminComponent', () => {
  let component: TdbayAdminComponent;
  let fixture: ComponentFixture<TdbayAdminComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TdbayAdminComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TdbayAdminComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
