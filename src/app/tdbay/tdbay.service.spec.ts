import { TestBed } from '@angular/core/testing';

import { TDBayService } from './tdbay.service';

describe('TDBayServiceService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: TDBayService = TestBed.get(TDBayService);
    expect(service).toBeTruthy();
  });
});
