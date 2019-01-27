import { TestBed } from '@angular/core/testing';

import { DesignContractService } from './design-contract.service';

describe('DesignContractService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: DesignContractService = TestBed.get(DesignContractService);
    expect(service).toBeTruthy();
  });
});
